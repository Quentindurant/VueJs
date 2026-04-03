<template>
    <div class="step">
        <p>nom du produit?</p>
        <input type="text" placeholder="title" :value="modelValue" @input="$emit('update:modelValue', $event.target.value)">
    </div>
</template>

<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>
