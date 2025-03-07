const prodName = document.getElementById('prodName');
const standard = document.getElementById('standard');
const quantity = document.getElementById('quantity');
const hospName = document.getElementById('hospName');
const call = document.getElementById('call');
const email = document.getElementById('email');
const details = document.getElementById('details');

// 장바구니 로직
function addCart(prodName, standard, quantity) {
    var cart = getCart();
    cart[prodName] = { 
        prodName: prodName, 
        standard: standard, 
        quantity: quantity, 
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
    if(
        quantity.value != ''
    )  {
        addCart(prodName.value, standard.value, quantity.value);
    }
}

// order-btn
document.getElementById('order-btn').addEventListener('click', async (e) => {
    e.preventDefault();
    if(
        quantity.value != ''
    ) {
        order();
    }
});

// order form 로직
async function order() {
    const products = {
        prodName: prodName.value,
        standard: standard.value,
        quantity: quantity.value,
    }

    const encodedProducts = encodeURIComponent(JSON.stringify(products));
    const url = '../order/orderform.html?products='+encodedProducts;
    window.location.href = url;
}

// 수량 input 마이너스값 제한
document.getElementById('quantity').addEventListener('input', (e) => {
    var regex = /^\d+$/;
    if (!regex.test(e.target.value)) { 
        e.target.value = '';
    }
});

