/**
 * DigiSales Media - Shared JS
 * Handles: Book a Call smart link + Floating WhatsApp button
 */
(function () {
  'use strict';

  /* ─── 1. BOOK A CALL – smart phone/desktop handler ─── */
  function isMobilePhone() {
    // Use modern API if available
    if (navigator.userAgentData && typeof navigator.userAgentData.mobile === 'boolean') {
      return navigator.userAgentData.mobile;
    }
    // Fallback: UA sniff — phone only (NOT tablets)
    return /Android.*Mobile|iPhone|iPod|Windows Phone/i.test(navigator.userAgent);
  }

  var WA_BOOK_CALL = 'https://wa.me/919977504949?text=Hi%20DigiSales%20Media%2C%20I%20would%20like%20to%20book%20a%20call.';

  document.addEventListener('click', function (e) {
    var el = e.target.closest('[data-book-call]');
    if (!el) return;
    if (!isMobilePhone()) {
      e.preventDefault();
      window.open(WA_BOOK_CALL, '_blank', 'noopener,noreferrer');
    }
    // phones: do nothing — let the tel: href work
  });

  /* ─── 2. FLOATING WHATSAPP BUTTON ─── */
  var WA_FLOAT_URL = 'https://wa.me/919977504949?text=Hi%20DigiSales%20Media%2C%20I%20want%20to%20know%20more%20about%20your%20services.';
  var BUBBLE_MSG   = 'Chat with us on WhatsApp';

  function addFloatingWhatsApp() {
    // Prevent duplicates
    if (document.getElementById('ds-wa-float')) return;

    // Styles
    var style = document.createElement('style');
    style.id = 'ds-wa-float-styles';
    style.textContent = [
      '#ds-wa-float{position:fixed;right:24px;bottom:24px;z-index:9999;display:flex;flex-direction:column;align-items:flex-end;gap:8px;}',
      '#ds-wa-float-btn{width:60px;height:60px;border-radius:50%;background:#25D366;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 16px rgba(37,211,102,0.45);text-decoration:none;transition:transform .2s;position:relative;}',
      '#ds-wa-float-btn:hover{transform:scale(1.1);}',
      '#ds-wa-float-btn svg{width:32px;height:32px;fill:#fff;flex-shrink:0;}',
      '@keyframes ds-wa-pulse{0%{box-shadow:0 0 0 0 rgba(37,211,102,.55);}70%{box-shadow:0 0 0 14px rgba(37,211,102,0);}100%{box-shadow:0 0 0 0 rgba(37,211,102,0);}}',
      '#ds-wa-float-btn{animation:ds-wa-pulse 2s infinite;}',
      '@media(prefers-reduced-motion:reduce){#ds-wa-float-btn{animation:none;}}',
      '#ds-wa-bubble{background:#fff;color:#1a1a1a;font-size:13px;font-weight:500;padding:8px 14px;border-radius:20px 20px 4px 20px;box-shadow:0 2px 12px rgba(0,0,0,0.18);white-space:nowrap;opacity:0;transform:translateY(6px);transition:opacity .3s,transform .3s;pointer-events:none;}',
      '#ds-wa-bubble.ds-show{opacity:1;transform:translateY(0);}',
      '#ds-wa-float-btn[data-tooltip]:hover::after{content:attr(data-tooltip);position:absolute;right:70px;top:50%;transform:translateY(-50%);background:#fff;color:#1a1a1a;font-size:12px;font-weight:500;padding:6px 12px;border-radius:16px;box-shadow:0 2px 10px rgba(0,0,0,0.15);white-space:nowrap;pointer-events:none;}',
      '@media(max-width:599px){#ds-wa-float-btn{width:54px;height:54px;}#ds-wa-float-btn svg{width:28px;height:28px;}#ds-wa-float{right:16px;bottom:16px;}}'
    ].join('');
    document.head.appendChild(style);

    // Build wrapper
    var wrap = document.createElement('div');
    wrap.id = 'ds-wa-float';

    // Bubble
    var bubble = document.createElement('div');
    bubble.id = 'ds-wa-bubble';
    bubble.textContent = BUBBLE_MSG;

    // Button
    var btn = document.createElement('a');
    btn.id = 'ds-wa-float-btn';
    btn.href = WA_FLOAT_URL;
    btn.target = '_blank';
    btn.rel = 'noopener noreferrer';
    btn.setAttribute('aria-label', 'Chat with us on WhatsApp');
    btn.setAttribute('data-tooltip', BUBBLE_MSG);
    btn.innerHTML = '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M17.47 14.38c-.26-.13-1.52-.75-1.76-.83s-.41-.13-.58.13-.67.83-.82 1-.3.19-.56.06a7.04 7.04 0 0 1-2.07-1.28 7.76 7.76 0 0 1-1.43-1.79c-.15-.26 0-.4.11-.53s.26-.3.39-.45a1.74 1.74 0 0 0 .26-.43.48.48 0 0 0 0-.46c-.06-.13-.58-1.4-.79-1.91s-.42-.43-.58-.44h-.49a.94.94 0 0 0-.68.32 2.87 2.87 0 0 0-.9 2.14 5 5 0 0 0 1.04 2.65 11.44 11.44 0 0 0 4.38 3.87 13.6 13.6 0 0 0 1.46.54 3.51 3.51 0 0 0 1.61.1 2.64 2.64 0 0 0 1.73-1.22 2.14 2.14 0 0 0 .15-1.22c-.07-.1-.24-.16-.5-.29zM12 2a10 10 0 0 0-8.7 14.93L2 22l5.25-1.38A10 10 0 1 0 12 2zm0 18.18A8.18 8.18 0 0 1 7.75 19l-.31-.18-3.12.82.83-3.04-.2-.32A8.18 8.18 0 1 1 12 20.18z"/></svg>';

    wrap.appendChild(bubble);
    wrap.appendChild(btn);
    document.body.appendChild(wrap);

    // Show bubble after 3s, hide after 6s — only once per session
    try {
      if (!sessionStorage.getItem('ds-wa-bubble-shown')) {
        setTimeout(function () {
          bubble.classList.add('ds-show');
          setTimeout(function () {
            bubble.classList.remove('ds-show');
          }, 6000);
          sessionStorage.setItem('ds-wa-bubble-shown', '1');
        }, 3000);
      }
    } catch (e) { /* sessionStorage blocked */ }
  }

  // Run after DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addFloatingWhatsApp);
  } else {
    addFloatingWhatsApp();
  }

})();

