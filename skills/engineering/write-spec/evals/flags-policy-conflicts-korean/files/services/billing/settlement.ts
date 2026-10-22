export const settlement = {
  async record(entry: { subscriptionId: string; amount: number; reasonCode: string; actor: string }) {
    /* writes to the settlement ledger; reasonCode is required */
  },
};
