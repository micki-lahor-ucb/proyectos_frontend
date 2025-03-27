# Frontend de Gestión de Proyectos

Aplicación web para el sistema de gestión de proyectos y tareas.

## Tecnologías

- Vue 3 - Framework JavaScript
- Vue Router - Manejo de rutas
- Pinia - Gestión de estado
- Tailwind CSS - Framework CSS
- Axios - Cliente HTTP

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

### Para desarrollo:
```bash
npm run dev
```

### Para compilar para producción:
```bash
npm run build
```

### Para previsualizar la versión de producción:
```bash
npm run preview
```

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
