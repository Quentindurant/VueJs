<template>
  <div class="max-w-5xl mx-auto px-6 py-12">
    <div class="mb-8">
      <h1 class="text-3xl font-bold tracking-tight">Produits disponibles</h1>
      <p class="mt-2 text-muted-foreground">Liste de tous les produits créés.</p>
    </div>

    <p v-if="loading" class="text-muted-foreground">Chargement...</p>
    <p v-else-if="courses.length === 0" class="text-muted-foreground">Aucun produit trouvé.</p>

    <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <Card v-for="course in courses" :key="course.id" class="flex flex-col justify-between p-6">
        <div class="space-y-1 mb-4">
          <h2 class="font-semibold text-base leading-tight">{{ course.title }}</h2>
          <p class="text-sm text-muted-foreground">{{ course.instructor }}</p>
        </div>
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium">{{ course.price }} €</span>
          <Button variant="destructive" size="sm" @click="deleteCOurse(course.id)">Supprimer</Button>
        </div>
      </Card>
    </div>
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
  await fetch(`http://localhost:3000/api/courses/${id}`, { method: 'DELETE' })
  courses.value = courses.value.filter(course => course.id !== id)
}
</script>
