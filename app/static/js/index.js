(function () {
    'use strict';

    const input       = document.getElementById('searchInput');
    const clearBtn    = document.getElementById('searchClear');
    const cards       = document.querySelectorAll('.service-card');
    const emptyState  = document.getElementById('emptyState');
    const countBadge  = document.getElementById('sectionCount');
    const heroCount   = document.getElementById('visibleCount');
    const pills       = document.querySelectorAll('.pill');

    let activeFilter = 'all';
    let searchQuery  = '';

    // ── Moteur de filtrage ───────────────────────────────────────
    function applyFilters() {
        let visible = 0;

        cards.forEach(function (card) {
            const name = card.dataset.name  || '';
            const type = card.dataset.type  || '';
            const tags = card.dataset.tags  || '';

            const matchesSearch = searchQuery === '' ||
                name.includes(searchQuery) ||
                type.toLowerCase().includes(searchQuery) ||
                tags.includes(searchQuery);

            const matchesFilter = activeFilter === 'all' ||
                type === activeFilter ||
                type.includes(activeFilter);

            if (matchesSearch && matchesFilter) {
                card.classList.remove('hidden');
                visible++;
            } else {
                card.classList.add('hidden');
            }
        });

        // Compteurs
        const label = visible + ' service' + (visible > 1 ? 's' : '');
        countBadge.textContent = label;
        heroCount.textContent  = visible;

        // Empty state
        emptyState.classList.toggle('visible', visible === 0);
    }

    // ── Recherche ────────────────────────────────────────────────
    input.addEventListener('input', function () {
        searchQuery = this.value.trim().toLowerCase();
        clearBtn.classList.toggle('visible', searchQuery.length > 0);
        applyFilters();
    });

    // ── Effacer ──────────────────────────────────────────────────
    clearBtn.addEventListener('click', function () {
        input.value  = '';
        searchQuery  = '';
        this.classList.remove('visible');
        input.focus();
        applyFilters();
    });

    // ── Raccourci clavier : "/" pour focus ───────────────────────
    document.addEventListener('keydown', function (e) {
        if (e.key === '/' && document.activeElement !== input) {
            e.preventDefault();
            input.focus();
        }
        if (e.key === 'Escape' && document.activeElement === input) {
            input.blur();
        }
    });

    // ── Pills de filtrage ────────────────────────────────────────
    pills.forEach(function (pill) {
        pill.addEventListener('click', function () {
            pills.forEach(function (p) { p.classList.remove('active'); });
            this.classList.add('active');
            activeFilter = this.dataset.filter;
            applyFilters();
        });
    });

})();