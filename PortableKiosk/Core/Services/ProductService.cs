using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class ProductService
    {
        private readonly ProductRepository productRepository =
            new ProductRepository();

        private readonly ProductVariantRepository variantRepository =
            new ProductVariantRepository();

        public int AddProduct(Product product)
        {
            return productRepository.Add(product);
        }

        public List<Product> GetProducts()
        {
            return productRepository.GetAll();
        }

        public int AddVariant(ProductVariant variant)
        {
            return variantRepository.Add(variant);
        }

        public List<ProductVariant> GetVariants()
        {
            return variantRepository.GetAll();
        }
    }
}
