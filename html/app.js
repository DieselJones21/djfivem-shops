const app = document.getElementById('app');
const tabsEl = document.getElementById('tabs');
const gridEl = document.getElementById('grid');
const emptyEl = document.getElementById('empty');
const cartListEl = document.getElementById('cartList');
const cartEmptyEl = document.getElementById('cartEmpty');
const paymentPillsEl = document.getElementById('paymentPills');
const searchEl = document.getElementById('search');
const checkoutBtn = document.getElementById('checkoutBtn');

const isNui = typeof GetParentResourceName === 'function';

const state = {
    shop: null,
    player: null,
    categories: [],
    items: [],
    payments: ['cash'],
    method: 'cash',
    category: 'all',
    query: '',
    cart: {},
    maxQuantity: 25,
    busy: false,
};

const methodLabels = {
    cash: 'Cash',
    bank: 'Bank',
    black_money: 'Dirty',
};

const tabIcons = {
    all: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 4h7v7H4V4zm9 0h7v7h-7V4zM4 13h7v7H4v-7zm9 0h7v7h-7v-7z"/></svg>',
    food: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 2v9a3 3 0 0 0 3 3v8h2V2h-2v8H9V2H8zm8 3c-1.1 2.2-1.5 4-1.5 7V22h2V12c2-1 3.5-3.2 3.5-7h-4z"/></svg>',
    drinks: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h12l-1.2 14.4A3 3 0 0 1 13.82 20H10.18a3 3 0 0 1-2.98-2.6L6 3zm3.1 2-.3 3.6h6.4L15 5H9.1z"/></svg>',
    vapes: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 14h11v3H3v-3zm13 0h2v3h-2v-3zm3.5-6.5c1.4 0 2.5 1.1 2.5 2.5h-2c0-.3-.2-.5-.5-.5s-.5.2-.5.5h-2c0-1.4 1.1-2.5 2.5-2.5zM17 4c2.2 0 4 1.8 4 4h-2a2 2 0 0 0-2-2V4z"/></svg>',
    pistols: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 9h13l2 3h3v2h-4l-2 4H13l1.2-4H8v4H5V9H3V7h2V5h3v2h10v2H3z"/></svg>',
    rifles: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 11h15l3-3h2v2h-1.2L18 13v3h-2v-2H9v3H7v-3H2v-3z"/></svg>',
    shotguns: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12h14l4-4h2v2l-3.2 3.2L17 18h-2l1-4H9v3H7v-3H2v-2z"/></svg>',
    ammo: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 2h8v6l-2 12H10L8 8V2zm2 2v4h4V4h-4z"/></svg>',
    tools: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M21 7.2 16.8 3l-3.1 3.1A6 6 0 0 0 6 12.2L2 16.2 5.8 20l4-4A6 6 0 0 0 16 12l3.1-3.1L21 7.2z"/></svg>',
    phones: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M8 2h8a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2zm0 3v12h8V5H8z"/></svg>',
    comms: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3a9 9 0 0 1 9 9h-2a7 7 0 0 0-7-7V3zm0 4a5 5 0 0 1 5 5h-2a3 3 0 0 0-3-3V7zm-1 5h2v8h-2v-8z"/></svg>',
    electronics: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16v11H4V5zm2 2v7h12V7H6zm4 13h4v2h-4v-2z"/></svg>',
    breaching: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M13 2 4 14h7l-1 8 10-14h-7l0-6z"/></svg>',
    packaging: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 7l9-4 9 4v10l-9 4-9-4V7zm9 2 7-3-7-3-7 3 7 3z"/></svg>',
    supplies: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 3h10l1 5H6l1-5zm-1 7h12v11H6V10zm3 2v7h2v-7H9zm4 0v7h2v-7h-2z"/></svg>',
};

function nui(name, data) {
    if (!isNui) {
        return Promise.resolve({ ok: true, player: state.player });
    }

    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
    }).then((res) => res.json()).catch(() => ({ ok: false }));
}

function money(value) {
    const amount = Number(value || 0);
    return `$${amount.toLocaleString('en-US')}`;
}

function initials(name) {
    return String(name || 'C')
        .split(' ')
        .filter(Boolean)
        .slice(0, 2)
        .map((part) => part[0].toUpperCase())
        .join('');
}

function cartEntries() {
    return Object.values(state.cart);
}

function cartTotal() {
    return cartEntries().reduce((sum, line) => sum + line.price * line.count, 0);
}

function cartCount() {
    return cartEntries().reduce((sum, line) => sum + line.count, 0);
}

function closeUi() {
    app.classList.add('hidden');
    app.setAttribute('aria-hidden', 'true');
    state.cart = {};
    nui('close');
}

function setPlayer(player) {
    state.player = player;
    document.getElementById('playerName').textContent = player.name;
    document.getElementById('avatar').textContent = initials(player.name);
    document.getElementById('statCash').textContent = money(player.cash);
    document.getElementById('statBank').textContent = money(player.bank);
}

function renderPayments() {
    paymentPillsEl.innerHTML = '';
    state.payments.forEach((method) => {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = `pill${state.method === method ? ' active' : ''}`;
        button.textContent = methodLabels[method] || method;
        button.addEventListener('click', () => {
            state.method = method;
            renderPayments();
            renderCart();
        });
        paymentPillsEl.appendChild(button);
    });
}

function renderTabs() {
    tabsEl.innerHTML = '';
    const tabs = [{ id: 'all', label: 'All' }, ...state.categories];
    tabs.forEach((tab) => {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = `tab${state.category === tab.id ? ' active' : ''}`;
        button.innerHTML = `${tabIcons[tab.id] || ''}<span>${tab.label}</span>`;
        button.addEventListener('click', () => {
            state.category = tab.id;
            renderTabs();
            renderGrid();
        });
        tabsEl.appendChild(button);
    });
}

function visibleItems() {
    const query = state.query.trim().toLowerCase();
    return state.items.filter((item) => {
        const inCategory = state.category === 'all' || item.category === state.category;
        const inSearch = !query || item.label.toLowerCase().includes(query) || item.name.toLowerCase().includes(query);
        return inCategory && inSearch;
    });
}

function qtyFor(name) {
    return state.cart[name]?.count || 1;
}

function renderGrid() {
    const items = visibleItems();
    gridEl.innerHTML = '';
    emptyEl.classList.toggle('hidden', items.length > 0);

    const category = state.categories.find((entry) => entry.id === state.category);
    document.getElementById('categoryHint').textContent = category
        ? `${category.label} • ${items.length} items`
        : `${items.length} items available`;

    items.forEach((item) => {
        const card = document.createElement('article');
        card.className = `item-card${item.locked ? ' locked' : ''}`;

        const imageWrap = document.createElement('div');
        imageWrap.className = 'item-image';
        const img = document.createElement('img');
        img.alt = item.label;
        img.src = item.image;
        img.addEventListener('error', () => {
            img.style.display = 'none';
        });
        imageWrap.appendChild(img);

        const title = document.createElement('h3');
        title.textContent = item.label;

        const price = document.createElement('div');
        price.className = 'price';
        price.textContent = money(item.price);

        const qty = document.createElement('div');
        qty.className = 'qty';
        const minus = document.createElement('button');
        minus.type = 'button';
        minus.textContent = '−';
        const value = document.createElement('span');
        value.textContent = String(qtyFor(item.name));
        const plus = document.createElement('button');
        plus.type = 'button';
        plus.textContent = '+';

        minus.addEventListener('click', () => {
            const next = Math.max(1, Number(value.textContent) - 1);
            value.textContent = String(next);
        });
        plus.addEventListener('click', () => {
            const next = Math.min(state.maxQuantity, Number(value.textContent) + 1);
            value.textContent = String(next);
        });

        qty.append(minus, value, plus);

        const add = document.createElement('button');
        add.type = 'button';
        add.className = 'add-btn';
        add.textContent = item.locked ? 'License required' : 'Add to cart';
        add.disabled = Boolean(item.locked);
        add.addEventListener('click', () => addToCart(item, Number(value.textContent)));

        card.append(imageWrap, title, price, qty, add);
        if (item.locked) {
            const note = document.createElement('div');
            note.className = 'lock-note';
            note.textContent = 'Weapon license needed';
            card.appendChild(note);
        }
        gridEl.appendChild(card);
    });
}

function addToCart(item, count) {
    const current = state.cart[item.name];
    const nextCount = Math.min(state.maxQuantity, (current?.count || 0) + count);
    state.cart[item.name] = {
        name: item.name,
        label: item.label,
        price: item.price,
        count: nextCount,
    };
    renderCart();
}

function renderCart() {
    const lines = cartEntries();
    cartListEl.innerHTML = '';
    cartEmptyEl.classList.toggle('hidden', lines.length > 0);

    lines.forEach((line) => {
        const row = document.createElement('div');
        row.className = 'cart-row';

        const info = document.createElement('div');
        const title = document.createElement('strong');
        title.textContent = line.label;
        const meta = document.createElement('div');
        meta.className = 'cart-meta';
        meta.textContent = `${line.count} × ${money(line.price)}`;
        info.append(title, meta);

        const remove = document.createElement('button');
        remove.type = 'button';
        remove.className = 'icon-btn';
        remove.textContent = '×';
        remove.addEventListener('click', () => {
            delete state.cart[line.name];
            renderCart();
        });

        row.append(info, remove);
        cartListEl.appendChild(row);
    });

    const total = cartTotal();
    document.getElementById('statCart').textContent = money(total);
    document.getElementById('cartCountPill').textContent = `${cartCount()} items`;
    document.getElementById('checkoutTotal').textContent = money(total);
    document.getElementById('methodLabel').textContent = methodLabels[state.method] || state.method;
    checkoutBtn.disabled = lines.length === 0 || state.busy;
}

async function checkout() {
    if (state.busy || cartEntries().length === 0) return;
    state.busy = true;
    checkoutBtn.disabled = true;
    checkoutBtn.textContent = 'Processing...';

    const result = await nui('checkout', {
        method: state.method,
        cart: cartEntries().map((line) => ({ name: line.name, count: line.count })),
    });

    state.busy = false;
    checkoutBtn.textContent = 'Checkout';

    if (result && result.ok) {
        state.cart = {};
        if (result.player) setPlayer(result.player);
        renderCart();
        return;
    }

    renderCart();
}

function openUi(data) {
    state.shop = data.shop;
    state.categories = data.categories || [];
    state.items = data.items || [];
    state.payments = data.payments || ['cash'];
    state.method = state.payments[0];
    state.category = 'all';
    state.query = '';
    state.cart = {};
    state.maxQuantity = data.maxQuantity || 25;
    searchEl.value = '';

    document.getElementById('shopName').textContent = data.shop.label;
    document.getElementById('shopSubtitle').textContent = data.shop.location || data.shop.subtitle || 'Store';
    document.getElementById('closeHint').textContent = data.closeHint || 'ESC (Close Shop)';
    document.getElementById('footerBrand').textContent = data.resourceLabel || 'DJ FiveM Scripts';

    setPlayer(data.player);
    renderTabs();
    renderPayments();
    renderGrid();
    renderCart();

    app.classList.remove('hidden');
    app.setAttribute('aria-hidden', 'false');
}

searchEl.addEventListener('input', () => {
    state.query = searchEl.value;
    renderGrid();
});

checkoutBtn.addEventListener('click', checkout);

window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !app.classList.contains('hidden')) {
        event.preventDefault();
        closeUi();
    }
});

window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};
    if (action === 'open') openUi(data);
    if (action === 'close') {
        app.classList.add('hidden');
        app.setAttribute('aria-hidden', 'true');
    }
    if (action === 'purchased' && data && data.player) {
        setPlayer(data.player);
    }
});

function previewPayload() {
    const image = (name) => `data:image/svg+xml;utf8,${encodeURIComponent(
        `<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" rx="12" fill="#141414"/><text x="32" y="38" text-anchor="middle" fill="#d8d8d8" font-size="11" font-family="Inter,sans-serif">${name.slice(0, 6)}</text></svg>`
    )}`;

    return {
        shop: { label: '24/7', subtitle: 'Supermarket', location: 'Innocence Blvd' },
        resourceLabel: 'DJ FiveM Scripts',
        closeHint: 'ESC (Close Shop)',
        payments: ['cash', 'bank'],
        player: { name: 'Alex Reyes', cash: 3510, bank: 12450 },
        categories: [
            { id: 'food', label: 'Food' },
            { id: 'drinks', label: 'Drinks' },
            { id: 'vapes', label: 'Vapes' },
        ],
        items: [
            { name: 'sandwich', label: 'Sandwich', price: 4, category: 'food', image: image('food') },
            { name: 'cooking_ingredients', label: 'Cooking Ingredients', price: 4, category: 'food', image: image('cook') },
            { name: 'water', label: 'Water', price: 2, category: 'drinks', image: image('water') },
            { name: 'ecola', label: 'eCola', price: 3, category: 'drinks', image: image('ecola') },
            { name: 'vape', label: 'Vape Kit', price: 70, category: 'vapes', image: image('vape') },
            { name: 'vape_refill_strawberry', label: 'Strawberry Vape Juice', price: 15, category: 'vapes', image: image('juice') },
            { name: 'vape_elfbar_blueberry', label: 'Elfbar Blueberry', price: 20, category: 'vapes', image: image('elf') },
            { name: 'vape_elfbar_mango', label: 'Elfbar Mango', price: 20, category: 'vapes', image: image('elf') },
        ],
        maxQuantity: 25,
    };
}

if (!isNui) {
    openUi(previewPayload());
}
