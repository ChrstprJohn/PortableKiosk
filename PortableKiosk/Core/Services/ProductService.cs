using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class ProductService
    {
        private readonly ProductRepository productRepository =
            new ProductRepository();

        public int Add(Product product)
        {
            return productRepository.Add(product);
        }

        public Product GetByID(int productID)
        {
            return productRepository.GetByID(productID);
        }

        public Product GetAvailableByID(int productID)
        {
            return productRepository.GetAvailableByID(productID);
        }

        public List<Product> GetAll()
        {
            return productRepository.GetAll();
        }

        public List<Product> GetAvailableByCategoryID(
            int categoryID)
        {
            return productRepository.GetAvailableByCategoryID(
                categoryID);
        }

        public bool Update(Product product)
        {
            return productRepository.Update(product);
        }

        public bool Delete(int productID)
        {
            return productRepository.Delete(productID);
        }
    }
}
