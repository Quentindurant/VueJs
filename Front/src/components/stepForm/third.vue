<template>
    <div class="step">
        <p>description ?</p>
        <input type="text" placeholder="instructor" :value="modelValue" @input="$emit('update:modelValue', $event.target.value)">
    </div>
</template>

<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>
