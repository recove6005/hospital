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
        const li = document.createElement('li');
        li.innerHTML = `
            <input class="checkbox" id="${product}" type="checkbox" name="product" value="${product}">
            <img id="product-image" src="../images/main-${prodName}.png" alt="">
            <div id="product-details">
                <div id="product-name">${prodName}</div>
                <div id="product-standard">${cart[product].standard}</div>
                <div id="product-quantity">${cart[product].quantity}</div>
            </div>
        `;
        cartList.appendChild(li);
    }
}
displayCart();

document.getElementById('order-btn').addEventListener('click', async (e) => {
    var cart = getCart();

    const orderAllResponse = await fetch('/api/product/order-all', {
        method:'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify(cart),
    });

    if(orderAllResponse.ok) {
        Object.keys(cart).forEach(product => {
            delete cart[product];
        });
        setCart(cart);
        window.location.reload();
    } 
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