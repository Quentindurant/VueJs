import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import Form from '../form.vue'
import { createRouter, createMemoryHistory } from 'vue-router'

const router = createRouter({
    history: createMemoryHistory(),
    routes: [
        { path: '/', component: { template: '<div />' } }
    ]
})

beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn(() => Promise.resolve({
        ok: true,
        json: () => Promise.resolve([])
    })))
})

afterEach(() => {
    vi.unstubAllGlobals()
})

describe('Form', () => {
    it("le bouton previous est désac au départ", async () => {
        const wrapper = mount(Form, { global: { plugins: [router] } })
        const buttons = wrapper.findAll('button')
        expect(buttons[0].attributes('disabled')).toBeDefined()
    })

    it("cliquer next active le bouton previous à l'étape 1", async () => {
        const wrapper = mount(Form, { global: { plugins: [router] } })
        await wrapper.findAll('button')[1].trigger('click')
        const buttons = wrapper.findAll('button')
        expect(buttons[0].attributes('disabled')).toBeUndefined()
    })

    it("affiche le bouton Envoyer à la dernière étape", async () => {
        const wrapper = mount(Form, { global: { plugins: [router] } })
        await wrapper.findAll('button')[1].trigger('click')
        await wrapper.findAll('button')[1].trigger('click')
        const buttons = wrapper.findAll('button')
        expect(buttons[1].text()).toBe('Envoyer')
    })

})