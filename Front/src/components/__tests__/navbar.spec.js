import { describe, it, expect, afterEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import Navbar from '../partials/navbar.vue'
import { createRouter, createMemoryHistory } from 'vue-router'

/*

beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn(()=> Promise.resolve({
        ok: true,
        json: () => Promise.resolve([
            {id: 1, title: 'test1', price: 49.99, instructor: 'oui'}
        ])
    })))
})
*/

const createTestRouter = () => createRouter({
  history: createMemoryHistory(),
  routes: [
    { path: '/',        component: { template: '<div />' } },
    { path: '/preview', component: { template: '<div />' } },
    { path: '/contact', component: { template: '<div />' } },
  ]
})

describe('Navbar', () => {
    it('affiche 3 liens', () => {
        const router = createTestRouter()
        const wrapper = mount(Navbar, { global: { plugins: [router] } })
        expect(wrapper.findAll('a').length).toBe(3)
    })

    it('le lien Accueil pointe vers /', () => {
        const router = createTestRouter()
        const wrapper = mount(Navbar, { global: { plugins: [router] } })
        expect(wrapper.find('a[href="/"]').exists()).toBe(true)
    })

    it('le lien Preview pointe vers /preview', () => {
        const router = createTestRouter()
        const wrapper = mount(Navbar, { global: { plugins: [router] } })
        expect(wrapper.find('a[href="/preview"]').exists()).toBe(true)
    })

    it('le lien Contact pointe vers /contact', () => {
        const router = createTestRouter()
        const wrapper = mount(Navbar, { global: { plugins: [router] } })
        expect(wrapper.find('a[href="/contact"]').exists()).toBe(true)
    })
})

afterEach(() => {
    vi.unstubAllGlobals()
})
