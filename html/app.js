const app = document.getElementById('app');
const tabsEl = document.getElementById('tabs');
const gridEl = document.getElementById('grid');
const emptyEl = document.getElementById('empty');
const cartListEl = document.getElementById('cartList');
const cartEmptyEl = document.getElementById('cartEmpty');
const paymentPillsEl = document.getElementById('paymentPills');
const searchEl = document.getElementById('search');
const checkoutBtn = document.getElementById('checkoutBtn');

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

function nui(name, data) {
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
        button.textContent = tab.label;
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
    document.getElementById('brandMark').textContent = data.shop.label.slice(0, 2).toUpperCase();
    document.getElementById('closeHint').textContent = data.closeHint || 'ESC (Close Shop)';

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
