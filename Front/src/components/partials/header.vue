<template>
  <header class="border-b bg-card">
    <div class="max-w-5xl mx-auto px-6 py-4 flex items-center justify-between">
      <div class="flex items-center gap-2">
        <span class="text-lg font-semibold tracking-tight">CourseBuilder</span>
      </div>
      <nav class="flex items-center gap-6 text-sm font-medium text-muted-foreground">
        <RouterLink to="/" class="hover:text-foreground transition-colors">Accueil</RouterLink>
        <RouterLink to="/preview" class="hover:text-foreground transition-colors">Preview</RouterLink>
        <RouterLink to="/contact" class="hover:text-foreground transition-colors">Contact</RouterLink>
      </nav>
    </div>
  </header>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>
