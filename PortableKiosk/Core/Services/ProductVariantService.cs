using System;
using System.Collections.Generic;
using System.Linq;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class ProductVariantService
    {
        private readonly ProductVariantRepository variantRepository =
            new ProductVariantRepository();

        public int Add(ProductVariant variant)
        {
            return variantRepository.Add(variant);
        }

        public List<int> AddRange(
            IList<ProductVariant> variants)
        {
            if (variants == null || variants.Count == 0)
            {
                throw new ArgumentException(
                    "Select at least one variant to save.",
                    "variants");
            }

            int productID = variants[0].ProductID;

            if (variants.Any(
                variant => variant.ProductID != productID))
            {
                throw new ArgumentException(
                    "All variants in one save must belong to the same product.",
                    "variants");
            }

            bool hasDuplicateSizes = variants
                .GroupBy(variant => variant.SizeID)
                .Any(group => group.Count() > 1);

            if (hasDuplicateSizes)
            {
                throw new ArgumentException(
                    "Each size can only be selected once.",
                    "variants");
            }

            List<ProductVariant> existingVariants =
                variantRepository.GetByProductID(productID);

            bool alreadyExists = variants.Any(candidate =>
                existingVariants.Any(existing =>
                    existing.SizeID == candidate.SizeID));

            if (alreadyExists)
            {
                throw new ArgumentException(
                    "One or more selected sizes already exist for this product.",
                    "variants");
            }

            return variantRepository.AddRange(variants);
        }

        public ProductVariant GetByID(int productVariantID)
        {
            return variantRepository.GetByID(productVariantID);
        }

        public List<ProductVariant> GetAll()
        {
            return variantRepository.GetAll();
        }

        public List<ProductVariant> GetByProductID(
            int productID)
        {
            return variantRepository.GetByProductID(productID);
        }

        public List<ProductVariant> GetAvailableByProductID(
            int productID)
        {
            return variantRepository.GetAvailableByProductID(
                productID);
        }

        public ProductVariant GetAvailableByID(
            int productVariantID)
        {
            return variantRepository.GetAvailableByID(
                productVariantID);
        }

        public bool Update(ProductVariant variant)
        {
            if (variant == null)
            {
                throw new ArgumentNullException("variant");
            }

            List<ProductVariant> existingVariants =
                variantRepository.GetByProductID(
                    variant.ProductID);

            bool sizeAlreadyExists =
                existingVariants.Any(existing =>
                    existing.ProductVariantID !=
                        variant.ProductVariantID &&
                    existing.SizeID == variant.SizeID);

            if (sizeAlreadyExists)
            {
                throw new ArgumentException(
                    "That size already exists for this product.",
                    "variant");
            }

            return variantRepository.Update(variant);
        }

        public bool Delete(int productVariantID)
        {
            return variantRepository.Delete(productVariantID);
        }
    }
}
