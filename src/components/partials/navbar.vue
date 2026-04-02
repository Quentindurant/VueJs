<template>
    <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/about">About</RouterLink>
        <RouterLink to="/contact">Contact</RouterLink>
    </nav>
</template>

<style scoped>
nav {
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 1rem;
    background-color: #f5f5f5;
}

nav a {
    text-decoration: none;
    color: #333;
    font-weight: bold;
}

nav a:hover {
    color: #000;
}
</style>