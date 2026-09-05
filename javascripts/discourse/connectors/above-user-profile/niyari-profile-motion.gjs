import { modifier } from 'ember-modifier';


const profile_motion = modifier(() => {
  const desktop = window.matchMedia('(min-width: 48rem)');
  const reduced_motion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const animations = new Set();
  
  let frame;
  let observer;

  function cancel_animations() {
    cancelAnimationFrame(frame);
    observer?.disconnect();
    animations.forEach((animation) => animation.cancel());
    animations.clear();
  }

  function animate(element, keyframes) {
    const animation = element.animate(keyframes, {
      duration: 300,
      easing: 'cubic-bezier(0.22, 1, 0.36, 1)',
    });
    animations.add(animation);
    animation.onfinish = () => animations.delete(animation);
  }

  function onClick(event) {
    const button = event.target.closest?.('.user-profile-toggle-btn');
    const profile = button?.closest('.user-main .about');
    if (!profile || !desktop.matches || reduced_motion.matches) { return; }

    const height = profile.getBoundingClientRect().height;
    const collapsed = profile.classList.contains('collapsed-info');
    const elements = ['.user-profile-avatar', '.primary-textual'].map(
      (selector) => {
        const element = profile.querySelector(selector);
        return { selector, rect: element?.getBoundingClientRect() };
      },
    );
    cancel_animations();

    observer = new MutationObserver(() => {
      if (collapsed === profile.classList.contains('collapsed-info')) {
        return;
      }
      observer.disconnect();
      frame = requestAnimationFrame(() => {
        if (!profile.isConnected || collapsed === profile.classList.contains('collapsed-info') ) { return; }

        const target_h = profile.getBoundingClientRect().height;
        animate(profile, [ { height: `${height}px` }, { height: `${target_h}px` }, ]);

        for (const { selector, rect } of elements) {
          const element = profile.querySelector(selector);
          if (!element || !rect?.width || !rect.height) {
            continue;
          }
          const target = element.getBoundingClientRect();
          const scale =
            selector === '.user-profile-avatar' && target.width && target.height ? ` scale(${rect.width / target.width}, ${rect.height / target.height})` : '';
          animate(element, [
            {
              transformOrigin: 'top left',
              transform: `translate(${rect.left - target.left}px, ${rect.top - target.top}px)${scale}`,
            },
            { transformOrigin: 'top left', transform: 'none' },
          ]);
        }

        if (collapsed) {
          for (const content of profile.querySelectorAll('.secondary, .bio')) {
            animate(content, [ { opacity: 0, transform: 'translateY(8px)' }, { opacity: 1, transform: 'none' } ]);
          }
        }
      });
    });
    observer.observe(profile, { attributes: true, attributeFilter: ['class'] });
  }

  document.addEventListener('click', onClick, true);
  desktop.addEventListener('change', cancel_animations);
  reduced_motion.addEventListener('change', cancel_animations);
  
  return () => {
    document.removeEventListener('click', onClick, true);
    desktop.removeEventListener('change', cancel_animations);
    reduced_motion.removeEventListener('change', cancel_animations);
    cancel_animations();
  };
});

export default <template>
  <span hidden {{profile_motion}}></span>
</template>;
