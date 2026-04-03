<template>
    <Menubar>
        <nav>
            <RouterLink to="/">Accueil</RouterLink>
            <RouterLink to="/preview">Preview</RouterLink>
            <RouterLink to="/contact">Contact</RouterLink>
        </nav>
    </Menubar>
</template>

<script setup>
    import { Menubar } from '../ui/menubar'
</script>