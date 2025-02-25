function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

function displayCart() {
    var cart = getCart();
    var cartList = document.getElementById('shoppingbag-list');
    cartList.innerHTML = '';
    
    for(var product in cart) {
        var prodName = '-';
        if(cart[product].prodName === 'forcep') prodName = 'forcep';
        if(cart[product].prodName === 'snare') prodName = 'snare';
        if(cart[product].prodName === 'injector') prodName = 'injector';

        const li = document.createElement('li');
        li.innerHTML = `
            <input class="checkbox" type="checkbox">
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