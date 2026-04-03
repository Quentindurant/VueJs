<template>
    <div class="step">
        <p>prix ?</p>
        <input type="text" placeholder="price" :value="modelValue" @input="$emit('update:modelValue', $event.target.value)">
    </div>
</template>

<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>
