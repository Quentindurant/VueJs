<template>
  <div class="space-y-3">
    <div>
      <label class="text-sm font-medium leading-none">Prix</label>
      <p class="text-sm text-muted-foreground mt-1">Indiquez le prix en euros (0 pour gratuit).</p>
    </div>
    <input
      type="number"
      placeholder="ex: 29"
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
