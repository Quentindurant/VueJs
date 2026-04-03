
<template>
    <div class="steps">
        <Card>
            <Transition>
                <component :is="steps[currentStep].component" v-model="formData[steps[currentStep].field]" />
            </Transition>
            <Button @click="previousStep" :disabled="currentStep === 0">Previous</Button>
            <Button v-if="currentStep < steps.length - 1" @click="nextStep">Next</Button>
            <Button v-else @click="submit">Envoyer</Button>
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
    import { ref, reactive } from 'vue'
    import First from './stepForm/first.vue'
    import Second from './stepForm/second.vue'
    import Third from './stepForm/third.vue'
    import { Card } from './ui/card'
    import { Button } from './ui/button'

    const steps = [
        { name: 'first',  component: First,  field: 'title' },
        { name: 'second', component: Second, field: 'price' },
        { name: 'third',  component: Third,  field: 'instructor' },
    ]

    const currentStep = ref(0)

    const formData = reactive({
        title: '',
        price: '',
        instructor: '',
    })

    const previousStep = () => {
        currentStep.value--
    }
    const nextStep = () => {
        currentStep.value++
    }

    const submit = async () => {
        try {
            const res = await fetch('http://localhost:3000/api/courses', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            })
            const data = await res.json()
            if (!res.ok) throw new Error(data.error)
            alert('Cours créé !')
            formData.title = ''
            formData.price = ''
            formData.instructor = ''
            currentStep.value = 0
        } catch (err) {
            alert('Erreur : ' + err.message)
        }
    }
</script>
