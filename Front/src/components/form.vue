
<template>
    <div class="steps">
        <Card>
            <Transition>
                <component :is="steps[currentStep].component" />
            </Transition>
            <Button @click="previousStep">Previous</Button>
            <Button @click="nextStep">Next</Button>
        </Card>
    </div>
</template>
<style scoped>
    .v-enter-active,
    .v-leave-active {
        transition: opacity 0.5s ease;
    }

    .v-enter-from,
    .v-leave-to {
        opacity: 0;
    }
</style>
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