# Frontend de Gestión de Proyectos

Aplicación web para el sistema de gestión de proyectos y tareas con pipeline de Continuous Delivery.

## 🚀 Características

- ✅ Vue 3 + Composition API
- ✅ Vue Router para navegación SPA
- ✅ Pinia para gestión de estado
- ✅ Tailwind CSS para estilos
- ✅ Axios para comunicación con API
- ✅ Vitest para testing
- ✅ ESLint para linting
- ✅ **CD Pipeline con deploy automático a Staging y Production**
- ✅ **Despliegue atómico vía symlinks**
- ✅ **Rollback automático en caso de fallo**
- ✅ **Approvals obligatorios para producción**

## 📋 Tecnologías

- **Vue 3** - Framework JavaScript progresivo
- **Vue Router** - Manejo de rutas SPA
- **Pinia** - Gestión de estado moderna para Vue
- **Tailwind CSS** - Framework CSS utility-first
- **Axios** - Cliente HTTP
- **Vite** - Build tool ultrarrápido
- **Vitest** - Framework de testing
- **GitHub Actions** - CI/CD automation

## Requisitos

- Node.js (v14.x o superior)
- npm o yarn

## Instalación

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/micki-lahor-ucb/proyectos_frontend.git
   cd project-management-frontend
   ```

2. Instalar dependencias:
   ```bash
   npm install
   ```

3. Configurar variables de entorno:
   - Crear archivo `.env.local` basado en `.env.development`
   - Ajustar la URL de la API si es necesario:
     ```ini
     VITE_API_URL=http://localhost:3000/api
     ```

## Ejecución

### Desarrollo Local:
```bash
npm run dev
# Aplicación disponible en http://localhost:5173
```

### Testing:
```bash
# Ejecutar tests una vez
npm run test

# Ejecutar tests en modo watch
npm run test:watch

# Ejecutar linter
npm run lint:check
```

### Build para Producción:
```bash
# Compilar para producción
npm run build

# Preview del build
npm run preview
```

## 🚀 Continuous Delivery

Este proyecto implementa un pipeline completo de CD con despliegue a múltiples ambientes.

### Despliegue Automático

**Staging:** Se despliega automáticamente al hacer merge/push a `main`
```bash
git push origin main
# ✅ Deploy automático a staging
```

**Production:** Requiere crear un tag y aprobación manual
```bash
git tag -a v1.0.0 -m "release: production deployment"
git push origin v1.0.0
# ⏸️ Espera aprobación del Release Manager
# ✅ Deploy a producción tras aprobación
```

### Arquitectura de Deployment

```
/var/www/frontend/
├── releases/
│   ├── 20260128_143022_a3b4c5d/    # Release 1
│   ├── 20260128_145033_f6e7a8b/    # Release 2
│   └── 20260128_150044_c9d0e1f/    # Release 3 (actual)
├── current -> releases/20260128_150044_c9d0e1f  # Symlink atómico
└── shared/
    └── .env  # Config por ambiente
```

### Features del Pipeline

- ✅ **Build único** - Un artefacto para todos los ambientes
- ✅ **Symlinks atómicos** - Zero-downtime deployments
- ✅ **Health checks** - Verificación automática post-deploy
- ✅ **Rollback automático** - Si falla el health check
- ✅ **Approvals** - Requerido para producción
- ✅ **Release traceability** - Cada deploy tiene metadata

### Documentación Completa

Ver [CD-DEPLOYMENT-GUIDE.md](./CD-DEPLOYMENT-GUIDE.md) para:
- Configuración de secrets
- Estructura de servidores
- Proceso de rollback
- Troubleshooting
- Evidencias para evaluación

## Estructura de la aplicación

- `/src/assets` - Recursos estáticos
- `/src/components` - Componentes reutilizables
- `/src/composables` - Composables de Vue para funcionalidad reutilizable
- `/src/router` - Configuración de rutas
- `/src/services` - Servicios para comunicación con la API
- `/src/stores` - Almacenes Pinia para gestión de estado
- `/src/views` - Componentes de página/vista

## Rutas

- `/` - Página de inicio
- `/login` - Inicio de sesión
- `/register` - Registro de usuario
- `/projects` - Lista de proyectos
- `/projects/:id` - Detalle de un proyecto y sus tareas
- `/tasks` - Lista de todas las tareas

## Funcionalidades

### Autenticación

- Registro de nuevos usuarios
- Inicio de sesión
- Cierre de sesión
- Protección de rutas para usuarios autenticados

### Gestión de Proyectos

- Crear, leer, actualizar y eliminar proyectos
- Filtrar y buscar proyectos
- Ver estadísticas de proyectos

### Gestión de Tareas

- Crear, leer, actualizar y eliminar tareas
- Filtrar y buscar tareas
- Marcar tareas como completadas
- Organizar tareas por proyecto
- Priorizar tareas
- Asignar fechas límite
