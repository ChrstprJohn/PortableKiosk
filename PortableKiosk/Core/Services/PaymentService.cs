using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class PaymentService
    {
        private readonly PaymentRepository paymentRepository =
            new PaymentRepository();

        public int Add(Payment payment)
        {
            return paymentRepository.Add(payment);
        }

        public Payment GetByID(int paymentID)
        {
            return paymentRepository.GetByID(paymentID);
        }

        public Payment GetByOrderID(int orderID)
        {
            return paymentRepository.GetByOrderID(orderID);
        }

        public List<Payment> GetAll()
        {
            return paymentRepository.GetAll();
        }

        public bool Update(Payment payment)
        {
            return paymentRepository.Update(payment);
        }

        public bool Delete(int paymentID)
        {
            return paymentRepository.Delete(paymentID);
        }
    }
}
