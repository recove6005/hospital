// 장바구니 로직
function addCart(name, standard, quantity) {
    var cart = getCart();
    cart[name] = { name: name, standart: standard, quantity: quantity};
    setCart(cart);
}

function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

function setCart(cart) {
    document.cookie = "cart="+JSON.stringify(cart) + ";max-age=3600;path=/";
}


// 장바구니 담기
// document.getElementById('product-options').addEventListener('submit', (e) => {
//     const name = document.getElementById('product-name');
//     const standard = document.getElementById('product-standard');
//     const quantity = document.getElementById('product-quantity');
//     console.log(`name: ${name.value}, standart: ${standard.value}, quentity: ${quantity.value}`);
//     addCart(name.value, standard.value, quantity.value);
//     displayCart();
// });


function displayCart() {
    var cart = getCart();
    // var cartList = document.getElementById('cart');
    // cartList.innerHTML = '';

    console.log(`cart: ${cart}`);

    for(var product in cart) {
        // var item = document.createElement('li');
        // item.textContent = product + " - $" + cart[product].price + " x " + cart[product].quantity;
        // cartList.appendChild(item);

        console.log(`cart: ${cart[product]}-${cart[product].name}-${cart[product].standart}-${cart[product].quantity}`);
    }
}


// 수량 input 마이너스값 제한
document.getElementById('quantity').addEventListener('input', (e) => {
    var regex = /^\d+$/;
    if (!regex.test(e.target.value)) { 
        e.target.value = '';
    }
});

