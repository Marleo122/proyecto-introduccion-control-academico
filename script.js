
        let ultimoScroll = 0;
        const menu = document.getElementById('menu');
        const scrollIndicador = document.getElementById('scrollIndicador');
        let timeoutId;

        
        window.addEventListener('scroll', function() {
            const scrollActual = window.pageYOffset || document.documentElement.scrollTop;
            
           
            if (scrollActual > ultimoScroll && scrollActual > 50) {
        
                menu.classList.add('oculto');
                
            
                if (scrollIndicador) {
                    scrollIndicador.style.opacity = '0.5';
                    scrollIndicador.textContent = '';
                 
                    clearTimeout(timeoutId);
                    timeoutId = setTimeout(() => {
                        scrollIndicador.style.opacity = '0';
                    }, 2000);
                }
            } else if (scrollActual < ultimoScroll) {
          
                menu.classList.remove('oculto');
                
              
                if (scrollIndicador) {
                    scrollIndicador.style.opacity = '1';
                    scrollIndicador.textContent = '';
                    clearTimeout(timeoutId);
                    timeoutId = setTimeout(() => {
                        scrollIndicador.style.opacity = '0';
                    }, 3000);
                }
            }
      
            ultimoScroll = scrollActual;
            
   
            if (scrollActual === 0) {
                menu.classList.remove('oculto');
            }
        });

        const menuIcono = document.getElementById('menuIcono');
        const navLinks = document.getElementById('navLinks');

        if (menuIcono && navLinks) {
            menuIcono.addEventListener('click', function() {
                navLinks.classList.toggle('activo');
                
                // Animación del icono hamburguesa
                const spans = menuIcono.querySelectorAll('span');
                if (navLinks.classList.contains('activo')) {
                    spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
                    spans[1].style.opacity = '0';
                    spans[2].style.transform = 'rotate(-45deg) translate(7px, -6px)';
                } else {
                    spans[0].style.transform = 'none';
                    spans[1].style.opacity = '1';
                    spans[2].style.transform = 'none';
                }
            });

            // Cerrar menú al hacer clic en un enlace
            const enlaces = navLinks.querySelectorAll('a');
            enlaces.forEach(enlace => {
                enlace.addEventListener('click', () => {
                    navLinks.classList.remove('activo');
                    const spans = menuIcono.querySelectorAll('span');
                    spans[0].style.transform = 'none';
                    spans[1].style.opacity = '1';
                    spans[2].style.transform = 'none';
                });
            });
        }
    