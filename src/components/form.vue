<template>
    <div class="steps">
        <component :is="steps[currentStep].component" />
        <button @click="previousStep">Previous</button>
        <button @click="nextStep">Next</button>
    </div>
</template>

<script setup>
    import { ref } from 'vue'
    import First from './stepForm/first.vue'
    import Second from './stepForm/second.vue'
    import Third from './stepForm/third.vue'

    const steps = [
        { name: 'first',  component: First },
        { name: 'second', component: Second },
        { name: 'third',  component: Third },
    ]

    const currentStep = ref(0)

    const previousStep = () => {
        if (currentStep.value > 0) currentStep.value--
    }
    const nextStep = () => {
        if (currentStep.value < steps.length - 1) currentStep.value++
    }
</script>