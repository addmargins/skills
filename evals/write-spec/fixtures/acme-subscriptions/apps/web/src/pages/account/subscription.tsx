export default function SubscriptionPage({ sub }) {
  return (
    <section>
      <h1>내 구독</h1>
      <p>{sub.planName} · 다음 결제일 {sub.endsAt}</p>
      {/* Annual plans cannot be canceled on the web today. */}
      <p className="muted">해지는 고객센터(1588-0000) 또는 채팅으로 문의해 주세요.</p>
    </section>
  );
}
