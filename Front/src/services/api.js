import axios from 'axios'

// L'URL de votre API Express (en dev : localhost:3000, en prod : votre domaine)
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json',
  },
})

// ─── Health ────────────────────────────────────────────────────────────────
export const getHealth = () => api.get('/health')

// ─── Exemple : Courses (adaptez selon vos vraies routes Express) ────────────
export const getCourses   = ()           => api.get('/courses')
export const getCourse    = (id)         => api.get(`/courses/${id}`)
export const createCourse = (data)       => api.post('/courses', data)
export const updateCourse = (id, data)   => api.put(`/courses/${id}`, data)
export const deleteCourse = (id)         => api.delete(`/courses/${id}`)

export default api
