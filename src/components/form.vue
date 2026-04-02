
<template>
    <div class="steps">
        <Card>
            <component :is="steps[currentStep].component" />
            <Button @click="previousStep">Previous</Button>
            <Button @click="nextStep">Next</Button>
        </Card>
    </div>
</template>

<script setup>
    import { ref } from 'vue'
    import First from './stepForm/first.vue'
    import Second from './stepForm/second.vue'
    import Third from './stepForm/third.vue'
    import { Card } from './ui/card'
    import { Button } from './ui/button'

    const steps = [
        { name: 'first',  component: First },
        { name: 'second', component: Second },
        { name: 'third',  component: Third },
    ]

    const currentStep = ref(0)

    const previousStep = () => {
        currentStep.value--
    }
    const nextStep = () => {
        currentStep.value++
    }
</script>