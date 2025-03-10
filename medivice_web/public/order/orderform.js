const hospName = document.getElementById('hospName');
const call = document.getElementById('call');
const email = document.getElementById('email');
const address = document.getElementById('address');

// order
async function displayProducts() {
    const urlParams = new URLSearchParams(window.location.search);
    const products = JSON.parse(decodeURIComponent(urlParams.get('products')));
    console.log(products);
}
displayProducts();

// order form 로직
async function submitInquiry() {
    const urlParams = new URLSearchParams(window.location.search);
    const products = JSON.parse(decodeURIComponent(urlParams.get('products')));
    const orderResponse = await fetch('/api/product/store-order-all', {
        method:'POST',
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({
            products, 
            hospName: hospName.value,
            call: call.value,
            email: email.value,
            address: address.value,
        }),
    });

    if(orderResponse.ok) {
        window.location.reload();
    } else {
        const orderResult = await orderResponse.json();
        console.log(`order error: ${orderResult.error}`);
    }
}

document.getElementById('order-form').addEventListener('submit', (e) => {
    e.preventDefault();
    submitInquiry();
});
