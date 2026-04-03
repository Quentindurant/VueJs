<template>
  <div class="preview">
    <h1>Affichage des super produit de la mort qui tue un peu</h1>
    <p v-if="loading">Chargement...</p>
    <p v-else-if="courses.length === 0">Aucun produit trouvé</p>
    <Card v-for="course in courses" :key="course.id">
      <p>Nom : {{ course.title }}</p>
      <p>Prix : {{ course.price }} €</p>
      <p>Description : {{ course.instructor }}</p>
      <Button @click="deleteCOurse(course.id)">Supprimer</Button>
    </Card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Card } from '../components/ui/card'
import { Button } from '../components/ui/button'

const courses = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await fetch('http://localhost:3000/api/courses')
    courses.value = await res.json()
  } catch (err) {
    console.error('Erreur:', err)
  } finally {
    loading.value = false
  }
})

const deleteCOurse = async (id) => {
  await fetch(`http://localhost:3000/api/courses/${id}`, {
    method: 'DELETE',
  })

  courses.value = courses.value.filter(course => course.id !== id)
}

</script>

<style>
@media (min-width: 1024px) {
  .preview {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
