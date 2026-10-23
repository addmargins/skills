// Payment gateway client.
// Gateway contract: partial cancellation is accepted only within 180 days of the
// original payment. After that the gateway returns E_PARTIAL_CANCEL_EXPIRED and
// the refund must be paid out another way.
export const pg = {
  async cancelPayment(paymentId: string, amount: number): Promise<{ ok: boolean; code?: string }> {
    return gatewayRequest("/payments/" + paymentId + "/cancel", { amount });
  },
};
declare function gatewayRequest(path: string, body: unknown): Promise<{ ok: boolean; code?: string }>;
