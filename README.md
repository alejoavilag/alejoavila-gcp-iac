# alejoavila-gcp-iac

Infraestructura del portafolio [alejoavila.com](https://alejoavila.com) como
código, en Terraform sobre Google Cloud. Diseñada para operar dentro de la capa
gratuita: **costo objetivo 0 USD/mes.**

## Estructura

```
modules/
├── ci-identity/    Workload Identity Federation + SA de despliegue
├── api-service/    Artifact Registry + Cloud Run + SA de ejecución
├── datastore/      Firestore en modo nativo
└── secrets/        Contenedores de Secret Manager
envs/
└── prod/           Composición del entorno productivo
```

Los módulos no conocen el entorno; `envs/prod` los compone. Agregar un entorno
es copiar ese directorio, cambiar el `prefix` del backend y los valores de
`terraform.tfvars`.

> **Un solo entorno a propósito.** La capa gratuita de Cloud Run es por cuenta de
> facturación, no por servicio: un segundo entorno activo competiría por la misma
> cuota y duplicaría el riesgo de superarla. El código ya soporta varios; se
> añadirán cuando haya una razón real.

## Decisiones de seguridad

**Sin llaves de servicio.** GitHub Actions se autentica por OIDC mediante
Workload Identity Federation. No existe ningún JSON de credenciales, ni en el
repositorio ni en los secretos de GitHub.

**Doble filtro sobre quién puede desplegar.** El proveedor OIDC exige que el
dueño del repositorio coincida (`attribute_condition`), y el binding de
`workloadIdentityUser` restringe además a la lista exacta de repositorios. Sin la
condición del proveedor, cualquier repositorio de GitHub del mundo podría pedir
credenciales de este proyecto.

**Los valores de los secretos nunca pasan por Terraform.** El módulo `secrets`
crea únicamente el contenedor. Un `google_secret_manager_secret_version` dejaría
el valor en texto plano dentro del estado, que vive en un bucket de GCS. Los
valores se cargan aparte:

```bash
echo -n "VALOR" | gcloud secrets versions add gemini-api-key --data-file=-
```

**Permiso mínimo.** El contenedor corre con una cuenta de servicio dedicada que
solo puede escribir en Firestore y leer sus tres secretos — nunca la cuenta por
defecto de Compute, que trae permisos de editor sobre todo el proyecto.

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

Requiere credenciales de aplicación apuntando al proyecto correcto:

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project alejoavila-web
```

```bash
cd envs/prod
terraform init
terraform plan
terraform apply
```

El estado vive en `gs://alejoavila-web-tfstate`, con versionado activo y acceso
público bloqueado.

## Lo que NO gestiona Terraform

Creado en el bootstrap y fuera del ciclo de vida de este código:

- El proyecto `alejoavila-web` y su vínculo de facturación
- El bucket de estado `alejoavila-web-tfstate`
- La alerta de presupuesto
- La habilitación inicial de APIs
- Los valores de los secretos

## Salidas

| Salida | Para qué |
|---|---|
| `workload_identity_provider` | Campo del mismo nombre en `google-github-actions/auth` |
| `deployer_service_account` | Campo `service_account` en esa misma acción |
| `api_url` | URL de Cloud Run |
| `api_service_name` | Destino del rewrite de Firebase Hosting |
| `artifact_repository` | Destino de `docker push` |
