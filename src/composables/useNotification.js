import { ref, h, render } from 'vue';
import Notification from '../components/Notification.vue';

export function useNotification() {
  const notifications = ref([]);
  
  const notify = (message, type = 'success', duration = 3000) => {
    const id = Date.now();
    
    // Crear un div contenedor para la notificación
    const container = document.createElement('div');
    document.body.appendChild(container);
    
    // Crear el componente de notificación
    const vnode = h(Notification, {
      type,
      message,
      duration,
      onClose: () => {
        // Eliminar la notificación del DOM cuando se cierre
        render(null, container);
        document.body.removeChild(container);
        
        // Eliminar la notificación del array
        const index = notifications.value.findIndex(n => n.id === id);
        if (index !== -1) {
          notifications.value.splice(index, 1);
        }
      }
    });
    
    // Renderizar el componente
    render(vnode, container);
    
    // Añadir la notificación al array
    notifications.value.push({
      id,
      message,
      type,
    });
  };
  
  return {
    notify,
    notifications,
  };
}