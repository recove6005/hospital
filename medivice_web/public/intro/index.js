const cartCnt = document.getElementById('cart-cnt');
const cntNumber = document.getElementById('cnt-number');
let cartItemCnt = 0;

document.addEventListener('DOMContentLoaded', () => {
    cartCnt.style.display = 'none';
    var cart = getCart();
    
    for(var item in cart) {
        if(cart[item].prodName === 'delete') continue;
        else cartItemCnt++;
    }

    if(cartItemCnt > 0) cartCnt.style.display = 'flex';
    cntNumber.innerText = cartItemCnt;
    
});

function getCart() {
    var cartCookie = document.cookie.replace(/(?:(?:^|.*;\s*)cart\s*\=\s*([^;]*).*$)|^.*$/, "$1");
    return cartCookie ? JSON.parse(cartCookie) : {};
}