<script setup>
import { RouterView } from 'vue-router'
import Header from './components/partials/header.vue'
import Footer from './components/partials/footer.vue'
</script>

<template>
  <div class="min-h-screen flex flex-col bg-background text-foreground">
    <Header />
    <main class="flex-1">
      <RouterView />
    </main>
    <Footer />
  </div>
</template>
