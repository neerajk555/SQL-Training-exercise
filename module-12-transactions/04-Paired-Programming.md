# Paired Programming — Transactions

## Challenge: Ticket Booking System — 35 min

**Setup:** Concert with limited seats. Both partners try to book same seat simultaneously.

**Tasks:**
1. Partner A: Start transaction, check seat availability
2. Partner B: Start transaction, check same seat
3. Both try to book - observe conflict
4. Implement proper locking with SELECT FOR UPDATE
5. Test again - verify only one succeeds

**Discuss:** Why FOR UPDATE is essential, deadlock scenarios, timeout strategies.

