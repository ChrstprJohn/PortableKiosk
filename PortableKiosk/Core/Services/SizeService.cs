using System.Collections.Generic;
using PortableKiosk.Core.Data.Repositories;
using PortableKiosk.Core.Models;

namespace PortableKiosk.Core.Services
{
    public class SizeService
    {
        private readonly SizeRepository sizeRepository =
            new SizeRepository();

        public int Add(Size size)
        {
            return sizeRepository.Add(size);
        }

        public Size GetByID(int sizeID)
        {
            return sizeRepository.GetByID(sizeID);
        }

        public List<Size> GetAll()
        {
            return sizeRepository.GetAll();
        }

        public bool Update(Size size)
        {
            return sizeRepository.Update(size);
        }

        public bool Delete(int sizeID)
        {
            return sizeRepository.Delete(sizeID);
        }
    }
}
