function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

function setCart(cart) {
    document.cookie = "cart="+JSON.stringify(cart) + ";max-age=3600;path=/";
}

function displayCart() {
    var cart = getCart();
    var cartList = document.getElementById('shoppingbag-list');
    cartList.innerHTML = '';
    
    for(var product in cart) {
        var prodName = '-';
        if(cart[product].prodName === 'delete') continue;
        if(cart[product].prodName === 'forcep') prodName = 'forcep';
        if(cart[product].prodName === 'snare') prodName = 'snare';
        if(cart[product].prodName === 'injector') prodName = 'injector';
        const div = document.createElement('div');
        div.id = 'product-container';
        div.innerHTML = `
            <div id="product-select">
                <input class="checkbox" id="${product}" type="checkbox" name="product" value="${product}">
            </div>
            <div id="product-image">
                <img id="product-image" src="../images/main-${prodName}.png" alt="">
            </div>
            <div id="product-name">${prodName}</div>
            <div id="product-standard">${cart[product].standard}</div>
            <div id="product-quantity">${cart[product].quantity}</div>
        `;
        cartList.appendChild(div);
    }
}
displayCart();

document.getElementById('order-btn').addEventListener('click', async (e) => {
    var cart = getCart();

    const encodedProducts = encodeURIComponent(JSON.stringify(cart));
    const url = '../order/orderform.html?products='+encodedProducts;
    window.location.href = url;
});

document.getElementById('delete-btn').addEventListener('click', (e) => {
    var cart = getCart();
    Object.keys(cart).forEach(product => {
        const target = document.getElementById(product);
        if(target?.checked) {
            delete cart[product];
        }
    });
    setCart(cart);
    window.location.reload();
});
