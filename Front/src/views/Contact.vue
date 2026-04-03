<template>
  <div class="max-w-5xl mx-auto px-6 py-12">
    <div class="mb-8">
      <h1 class="text-3xl font-bold tracking-tight">Contact</h1>
      <p class="mt-2 text-muted-foreground">Pour toute question, n'hésitez pas à me contacter.</p>
    </div>

    <Card class="max-w-sm p-6 space-y-4">
      <div class="space-y-1">
        <p class="text-sm font-medium">Nom</p>
        <p class="text-sm text-muted-foreground">Quentin Durant</p>
      </div>
      <div class="h-px bg-border" />
      <div class="space-y-1">
        <p class="text-sm font-medium">Email</p>
        <a href="mailto:quentin.durant49@orange.fr" class="text-sm text-muted-foreground hover:text-foreground transition-colors">
          quentin.durant49@orange.fr
        </a>
      </div>
      <div class="h-px bg-border" />
      <div class="space-y-1">
        <p class="text-sm font-medium">Téléphone</p>
        <a href="tel:+33648056181" class="text-sm text-muted-foreground hover:text-foreground transition-colors">
          06 48 05 61 81
        </a>
      </div>
    </Card>
  </div>
</template>

<script setup>
import { Card } from '../components/ui/card'
</script>
