<template>
  <div class="deck-logo" aria-hidden="true">
    <img src="/kotlin-logo.svg" alt="Kotlin logo" />
  </div>
</template>

<style scoped>
.deck-logo {
  position: fixed;
  right: 1.2rem;
  bottom: 1rem;
  z-index: 50;
  pointer-events: none;
}

.deck-logo img {
  width: 2.8rem;
  height: 2.8rem;
  display: block;
  filter: drop-shadow(0 10px 18px rgba(12, 36, 61, 0.22));
  opacity: 0.92;
}
</style>
