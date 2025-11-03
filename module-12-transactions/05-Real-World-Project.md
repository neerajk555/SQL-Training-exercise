# Real-World Project — Transaction-Safe Order System

## Project: Build Complete E-Commerce Checkout (90 min)

**Requirements:**
1. Validate cart items exist and in stock
2. Calculate totals (subtotal, tax, shipping)
3. Create order record
4. Deduct inventory for each item
5. Process payment (simulate)
6. Clear shopping cart
7. Handle errors at each step with proper rollback

**Deliverables:**
- Stored procedure for checkout process
- Error handling for: out of stock, payment failure, invalid data
- Transaction log table tracking all attempts
- Test cases for success and failure scenarios

**Evaluation:**
- ✅ All-or-nothing guarantee
- ✅ Proper locking to prevent overselling
- ✅ Detailed error messages
- ✅ Rollback on any failure

