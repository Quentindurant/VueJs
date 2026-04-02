<script setup>
import { RouterLink, RouterView } from 'vue-router'
import Header from './components/partials/header.vue'
import Footer from './components/partials/footer.vue'
import Navbar from './components/partials/navbar.vue'
</script>

<template>
  <Header />
    <Navbar />
    
      <RouterView />
  <Footer />
</template>

<style scoped>
header {
  background-color: red;
  padding: 10px;
}

footer {
  background-color: green;
  padding: 10px;
}

nav {
  background-color: blue;
  padding: 10px;
}
</style>
