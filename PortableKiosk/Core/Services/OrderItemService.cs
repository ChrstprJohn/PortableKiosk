using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class OrderItemService
    {
        private readonly OrderItemRepository orderItemRepository =
            new OrderItemRepository();

        public int Add(OrderItem item)
        {
            return orderItemRepository.Add(item);
        }

        public List<int> AddRange(IList<OrderItem> items)
        {
            return orderItemRepository.AddRange(items);
        }

        public OrderItem GetByID(int orderItemID)
        {
            return orderItemRepository.GetByID(orderItemID);
        }

        public List<OrderItem> GetByOrderID(int orderID)
        {
            return orderItemRepository.GetByOrderID(orderID);
        }

        public bool Update(OrderItem item)
        {
            return orderItemRepository.Update(item);
        }

        public bool Delete(int orderItemID)
        {
            return orderItemRepository.Delete(orderItemID);
        }
    }
}
