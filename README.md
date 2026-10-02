# alejoavila-gcp-iac

Infraestructura del portafolio [alejoavila.com](https://alejoavila.com) como
código, en Terraform sobre Google Cloud. Diseñada para operar dentro de la capa
gratuita: **costo objetivo 0 USD/mes.**

## Dos capas, y por qué

```
envs/bootstrap/   se aplica A MANO, con credenciales de usuario
  Workload Identity Federation
  Cuentas de servicio y sus roles de proyecto
  Acceso al bucket de estado

envs/prod/        la aplica CI con la identidad terraform-admin
  Artifact Registry
  Cloud Run
  Firestore
  Secret Manager
```

La separación no es organizativa, es de seguridad. Para que Terraform cree
cuentas de servicio y otorgue roles de proyecto necesita
`roles/iam.serviceAccountAdmin` y `roles/resourcemanager.projectIamAdmin`. **Una
identidad que puede otorgar roles IAM puede otorgarse a sí misma el rol de
propietario.** Si CI tuviera esos permisos, cualquiera capaz de inyectar un
commit tendría acceso efectivo de propietario del proyecto.

Al concentrar identidades y roles en `bootstrap`, la identidad que usa CI
administra recursos pero no puede otorgar permisos. No hay ruta de escalamiento.

El módulo `ci-identity` lo refuerza con una validación que rechaza `owner`,
`editor`, `projectIamAdmin` y `securityAdmin` en cualquier identidad de CI: el
error salta en `plan`, antes de tocar nada.

## Identidades

| Cuenta | Puede | Repositorios autorizados |
|---|---|---|
| `github-deployer` | Publicar en Hosting y desplegar revisiones de Cloud Run | shell, chat-widget, api |
| `terraform-admin` | Aplicar `envs/prod` | solo `alejoavila-gcp-iac` |
| `alejoavila-api-runtime` | Escribir en Firestore y leer sus secretos | ninguno: es la identidad del contenedor |

**Sin llaves de servicio.** La autenticación es por OIDC vía Workload Identity
Federation: GitHub presenta un token de una hora y Google lo canjea. No existe
ningún JSON de credenciales, ni en los repositorios ni en los secretos de GitHub.

**El filtro es doble.** El proveedor OIDC exige que coincida el dueño del
repositorio; el binding de `workloadIdentityUser` restringe además a la lista
exacta de repositorios por identidad. Lo verifica Google, no GitHub: aunque
alguien comprometiera el repositorio del shell, no podría tocar la
infraestructura.

## Otras decisiones de seguridad

**Los valores de los secretos nunca pasan por Terraform.** El módulo `secrets`
crea solo el contenedor. Un `google_secret_manager_secret_version` dejaría el
valor en texto plano dentro del estado, que vive en un bucket de GCS:

```bash
echo -n "VALOR" | gcloud secrets versions add gemini-api-key --data-file=-
```

**El acceso al estado está acotado al bucket**, no a todo Cloud Storage del
proyecto.

**El contenedor nunca usa la cuenta por defecto de Compute**, que trae permisos
de editor. El módulo lo valida y falla si se intenta.

## Control de gasto

| Mecanismo | Valor |
|---|---|
| Tope de instancias de Cloud Run | 2, validado en el módulo |
| Escalado a cero | `min_instance_count = 0` con `cpu_idle` |
| Limpieza de imágenes | conserva 5 versiones; la capa gratuita da 0,5 GB |
| Alerta de presupuesto | 4.000 COP (~1 USD) al 50%, 90% y 100% |

> La cuenta de facturación está en **pesos colombianos**. Cualquier umbral se
> expresa en COP, no en USD.

## Uso

### Primera vez: bootstrap manual

Es obligatorio que sea local: crea la identidad que CI usará después, así que
no puede ejecutarse desde CI.

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project alejoavila-web

cd envs/bootstrap
terraform init
terraform apply
```

De sus salidas sale `runtime_service_account_email` para `envs/prod`.

### Después: la capa de aplicación

En cada PR corre `plan` y se publica como comentario. Al mezclar a `master`
corre `apply`, detenido por el environment `infraestructura` hasta que alguien
lo aprueba.

Para aplicarla a mano:

```bash
cd envs/prod
terraform init
terraform apply
```

## Configuración requerida en GitHub

- Environment **`infraestructura`** con revisores requeridos. Es la compuerta
  humana antes de que algo toque la infraestructura real.
- Protección de la rama `master`: exigir pull request, exigir que pasen los
  checks, bloquear force-push.

## Lo que NO gestiona Terraform

Creado en el bootstrap manual y fuera del ciclo de vida de este código:

- El proyecto `alejoavila-web` y su vínculo de facturación
- El bucket de estado `alejoavila-web-tfstate`
- La alerta de presupuesto
- La habilitación inicial de APIs
- Los valores de los secretos
