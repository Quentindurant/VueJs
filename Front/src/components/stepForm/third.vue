<template>
  <div class="space-y-3">
    <div>
      <label class="text-sm font-medium leading-none">Description</label>
      <p class="text-sm text-muted-foreground mt-1">décris ton produit</p>
    </div>
    <input
      type="text"
      placeholder="ex: Jean Dupont"
      :value="modelValue"
      @input="$emit('update:modelValue', $event.target.value)"
      class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
    />
  </div>
</template>

<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>
