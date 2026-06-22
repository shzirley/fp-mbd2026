document.addEventListener('DOMContentLoaded', () => {
    const btnSelect = document.getElementById('btn-branch-select');
    const menu = document.getElementById('branch-dropdown-menu');
    const selectedNameEl = document.getElementById('selected-branch-name');

    if (!btnSelect || !menu) {
        console.warn('Branch dropdown elements not found on this page.');
        return;
    }

    // Toggle dropdown visibility
    btnSelect.addEventListener('click', (e) => {
        e.stopPropagation();
        menu.classList.toggle('hidden');
    });

    // Close dropdown on click outside
    document.addEventListener('click', (e) => {
        if (!menu.classList.contains('hidden') && !menu.contains(e.target) && e.target !== btnSelect) {
            menu.classList.add('hidden');
        }
    });

    // Fetch and populate branches
    fetch('/api/branches')
        .then(res => res.json())
        .then(branches => {
            if (!branches || branches.length === 0) return;

            // Load selected branch from localStorage
            let selectedBranch = null;
            const savedBranchStr = localStorage.getItem('selectedBranch');
            if (savedBranchStr) {
                try {
                    selectedBranch = JSON.parse(savedBranchStr);
                } catch(e) {
                    console.error('Error parsing selected branch', e);
                }
            }

            // If none saved or saved not in the list, default to first one
            if (!selectedBranch || !branches.some(b => b.id_cabang === selectedBranch.id_cabang)) {
                selectedBranch = branches[0];
                localStorage.setItem('selectedBranch', JSON.stringify(selectedBranch));
            }

            // Set button text
            selectedNameEl.textContent = selectedBranch.nama_cabang;

            // Populate menu
            menu.innerHTML = branches.map(b => {
                const isSelected = b.id_cabang === selectedBranch.id_cabang;
                return `
                    <button class="w-full text-left px-md py-2 text-sm font-label-md text-on-surface-variant hover:text-white hover:bg-surface-bright/20 flex items-center justify-between transition-colors ${isSelected ? 'bg-primary-container/20 text-primary-fixed border-l-2 border-primary' : ''}" data-id="${b.id_cabang}" data-name="${b.nama_cabang}" data-alamat="${b.alamat}">
                        <span>${b.nama_cabang}</span>
                        ${isSelected ? '<span class="material-symbols-outlined text-primary text-[16px]">check</span>' : ''}
                    </button>
                `;
            }).join('');

            // Attach click listeners to menu items
            menu.querySelectorAll('button').forEach(itemBtn => {
                itemBtn.addEventListener('click', () => {
                    const id = itemBtn.getAttribute('data-id');
                    const name = itemBtn.getAttribute('data-name');
                    const alamat = itemBtn.getAttribute('data-alamat');

                    const newSelection = { id_cabang: id, nama_cabang: name, alamat: alamat };
                    localStorage.setItem('selectedBranch', JSON.stringify(newSelection));

                    // Update UI text
                    selectedNameEl.textContent = name;

                    // Close menu
                    menu.classList.add('hidden');

                    // Dispatch custom event for dynamic pages
                    const event = new CustomEvent('branchChanged', { detail: newSelection });
                    document.dispatchEvent(event);

                    // Refresh page so schedules/movies reload for the newly selected branch
                    window.location.reload();
                });
            });
        })
        .catch(err => {
            console.error('Error fetching branches:', err);
        });
});
