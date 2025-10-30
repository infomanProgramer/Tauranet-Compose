<template>
  <div class="terminal" role="alert" aria-live="assertive">
    <pre class="line">┌──────────────────────────────────────────────────────────────┐</pre>
    <pre class="line title">│   TAURANET · Sistema de Restaurante                      │</pre>
    <pre class="line">├──────────────────────────────────────────────────────────────┤</pre>
    <pre class="line">│   Estado: <strong>ERROR</strong>                             │</pre>
    <pre class="line">│                                                              │</pre>
    <pre class="line">│   Detalle: {{ displayMessage }}                              │</pre>
    <pre class="line">│                                                              │</pre>
    <pre class="line">└──────────────────────────────────────────────────────────────┘</pre>
    <div class="line" style="margin-top:12px"><span class="muted">$</span> <span class="cursor">&nbsp;</span></div>
  </div>
</template>

<script>
export default {
  name: 'LicenseError',
  computed: {
    displayMessage() {
      const m = this.$route.query.m;
      return (m && String(m)) || 'Error de licencia.';
    }
  }
}
</script>

<style scoped>
html, body { height: 100%; }
body > #app { height: 100vh; }
:host, .terminal {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
}
.terminal {
  /* width: min(900px, 92vw); */
  width: 100vw;
  border: 2px solid #00ff88;
  padding: 20px 24px;
  box-shadow: 0 0 20px rgba(0,255,136,0.2);
  background: #0b0e10;
  color: #00ff88;
  font-family: "Fira Code", Consolas, Monaco, "Courier New", monospace;
  flex-direction: column;
}
.title { color: #7dfcbe; margin: 0 0 12px; }
.line { white-space: pre-wrap; color: #7dfcbe; line-height: 1.6; }
.muted { color: #54c99b; }
.cursor { display: inline-block; width: 10px; background: #00ff88; animation: blink 1s step-start infinite; }
@keyframes blink { 50% { opacity: 0; } }
</style>
