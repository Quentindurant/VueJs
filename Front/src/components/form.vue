
<template>
  <div class="max-w-lg mx-auto">
    <!-- Step indicators -->
    <div class="flex items-center justify-center gap-2 mb-6">
      <template v-for="(step, index) in steps" :key="step.name">
        <div
          :class="[
            'h-2 w-2 rounded-full transition-colors',
            index === currentStep ? 'bg-primary' : index < currentStep ? 'bg-primary/40' : 'bg-border'
          ]"
        />
        <div v-if="index < steps.length - 1" class="h-px w-8 bg-border" />
      </template>
    </div>

    <Card class="p-0">
      <CardHeader>
        <CardTitle class="text-base font-medium text-muted-foreground">
          Étape {{ currentStep + 1 }} / {{ steps.length }}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Transition>
          <component :is="steps[currentStep].component" v-model="formData[steps[currentStep].field]" />
        </Transition>
      </CardContent>
      <CardFooter class="justify-between gap-2">
        <Button variant="outline" @click="previousStep" :disabled="currentStep === 0">Précédent</Button>
        <Button v-if="currentStep < steps.length - 1" @click="nextStep">Suivant</Button>
        <Button v-else @click="submit">Envoyer</Button>
      </CardFooter>
    </Card>
  </div>
</template>
<style scoped>
    .v-enter-active,
    .v-leave-active {
        transition: opacity 0.3s ease;
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
    import { Card, CardHeader, CardContent, CardFooter, CardTitle } from './ui/card'
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

            if (Notification.permission === 'default') {
                await Notification.requestPermission()
            }
            if (Notification.permission === 'granted') {
                new Notification('Produit créé !', {
                    body: `"${formData.title}" a bien été publié.`,
                })
            }
                
            formData.title = ''
            formData.price = ''
            formData.instructor = ''
            currentStep.value = 0
        } catch (err) {
            new Notification('Erreur', { body: err.message }) // si permission accordée
            // fallback au cas oùùùùùù
            alert('Erreur : ' + err.message)
        }
    }
</script>
