const prodName = document.getElementById('prodName');
const standard = document.getElementById('standard');
const quantity = document.getElementById('quantity');
const hospName = document.getElementById('hospName');
const call = document.getElementById('call');
const email = document.getElementById('email');
const details = document.getElementById('details');

// 장바구니 로직
function addCart(prodName, standard, quantity, hospName, call, email, details) {
    var cart = getCart();
    console.log(`shop.`);
    cart[prodName] = { 
        prodName: prodName, 
        standard: standard, 
        quantity: quantity, 
        hospName: hospName, 
        call: call, 
        email: email, 
        details: details
    };
    setCart(cart);
}

function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}

function setCart(cart) {
    document.cookie = "cart="+JSON.stringify(cart) + ";max-age=3600;path=/";
}

// shoppingbag-btn
document.getElementById('shoppingbag-btn').addEventListener('click', (e) => {
    addToShoppingBag();
});

// shoppingbag form 로직
function addToShoppingBag() {
    addCart(prodName.value, standard.value, quantity.value, hospName.value, call.value, email.value, details.value);
}

// order-btn
document.getElementById('order-btn').addEventListener('click', (e) => {

});

// order form 로직
function submitInquiry() {

}


// 수량 input 마이너스값 제한
document.getElementById('quantity').addEventListener('input', (e) => {
    var regex = /^\d+$/;
    if (!regex.test(e.target.value)) { 
        e.target.value = '';
    }
});

