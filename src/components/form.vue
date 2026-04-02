<template>
    <div class="steps">
        <component :is="steps[currentStep].component" />
        <button @click="previousStep">Previous</button>
        <button @click="nextStep">Next</button>
    </div>
</template>

<script setup>
    import First from './stepForm/first.vue'
    import Second from './stepForm/second.vue'
    import Third from './stepForm/third.vue'

    const steps = [
        {
            name: 'first',
            component: First
        },
        {
            name: 'second',
            component: Second
        },
        {
            name: 'third',
            component: Third
        }
    ]

    const currentStep = ref(0)
    const previousStep = () => {
        step--;
    }
    const nextStep = () => {
        step++;
    }

    